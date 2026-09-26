pipeline {
    agent any

    environment {
        SERVICE_ID  = 'hanami-erp'
        SERVICE_NAME = 'Hanami ERP'
        DEPLOY_DIR  = 'D:\\apps\\hanami-erp'
        PORT        = '7783'
        RUBY_HOME = 'C:\\Tools\\Ruby33-x64'
    }

    stages {

stage('Install Ruby 3.3') {
    steps {
        powershell '''
            $rubyDir = $env:RUBY_HOME
            $rubyExe = Join-Path $rubyDir "bin\\ruby.exe"

            if (Test-Path $rubyExe) {
                Write-Host "Ruby ya esta instalado:"
                & $rubyExe --version
                exit 0
            }

            Write-Host "Ruby no encontrado. Instalando en: $rubyDir"

            # PowerShell/.NET antiguo puede intentar TLS 1.0 o TLS 1.1.
            # GitHub requiere TLS moderno.
            [Net.ServicePointManager]::SecurityProtocol = `
                [Net.SecurityProtocolType]::Tls12

            if (-not (Test-Path "C:\\Tools")) {
                New-Item `
                    -ItemType Directory `
                    -Path "C:\\Tools" `
                    -Force | Out-Null
            }

            $version = "3.3.6-1"
            $installerName = "rubyinstaller-devkit-$version-x64.exe"
            $installer = Join-Path $env:TEMP $installerName

            $url = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$version/$installerName"

            Write-Host "Descargando RubyInstaller..."
            Write-Host $url

            Invoke-WebRequest `
                -UseBasicParsing `
                -Uri $url `
                -OutFile $installer

            if (-not (Test-Path $installer)) {
                throw "No se pudo descargar RubyInstaller."
            }

            Write-Host "Instalando Ruby..."

            $process = Start-Process `
                -FilePath $installer `
                -ArgumentList @(
                    "/verysilent",
                    "/suppressmsgboxes",
                    "/norestart",
                    "/dir=$rubyDir"
                ) `
                -Wait `
                -PassThru

            if ($process.ExitCode -ne 0) {
                throw "El instalador de Ruby fallo con codigo $($process.ExitCode)"
            }

            if (-not (Test-Path $rubyExe)) {
                throw "Ruby no fue instalado correctamente en $rubyExe"
            }

            Write-Host "Ruby instalado:"
            & $rubyExe --version

            Write-Host "Verificando RubyGems..."
            & $rubyExe -S gem --version

            Write-Host "Instalando Bundler..."
            & $rubyExe -S gem install bundler --no-document

            if ($LASTEXITCODE -ne 0) {
                throw "No se pudo instalar Bundler."
            }

            & $rubyExe -S bundle --version

            Remove-Item `
                $installer `
                -Force `
                -ErrorAction SilentlyContinue
        '''
    }
}


        stage('Check Environment') {
            steps {
                bat '''
                    echo ==============================
                    echo RUBY
                    echo ==============================

                    "%RUBY_HOME%\\bin\\ruby.exe" --version
                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle --version

                    echo ==============================
                    echo GIT
                    echo ==============================

                    git --version

                    echo ==============================
                    echo NSSM
                    echo ==============================

                    "%NSSM_EXE%" version
                '''
            }
        }

        stage('Stop Service') {
            steps {
                bat '''
                    "%PYTHON_HOME%\\python.exe" "%SERVICE_MANAGER%" stop "%SERVICE_ID%"
                '''
            }
        }


        stage('Deploy Files') {
            steps {
                powershell '''
                    $source = $env:WORKSPACE
                    $destination = $env:DEPLOY_DIR

                    if (-not (Test-Path $destination)) {
                        New-Item `
                            -ItemType Directory `
                            -Path $destination `
                            -Force | Out-Null
                    }

                    robocopy `
                        $source `
                        $destination `
                        /MIR `
                        /XD ".git" "vendor" "tmp" "log" ".bundle" `
                        /XF ".env" "*.log"

                    $code = $LASTEXITCODE

                    # Robocopy: codigos 0 a 7 indican exito.
                    if ($code -gt 7) {
                        throw "Robocopy fallo con codigo $code"
                    }

                    exit 0
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                bat '''
                    cd /D "%DEPLOY_DIR%"

                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle config set path "vendor/bundle"
                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle config set without "development test"

                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle install ^
                        --jobs 4 ^
                        --retry 3 ^
                        --deployment

                    if errorlevel 1 (
                        echo ERROR: No se pudieron instalar las gemas.
                        exit /B 1
                    )
                '''
            }
        }

        stage('Verify Application') {
            steps {
                bat '''
                    cd /D "%DEPLOY_DIR%"

                    echo ==============================
                    echo HANAMI
                    echo ==============================

                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle exec hanami --version

                    if errorlevel 1 (
                        echo ERROR: Hanami no esta disponible.
                        exit /B 1
                    )

                    echo ==============================
                    echo BOOT APPLICATION
                    echo ==============================

                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle exec ruby ^
                        -e "require_relative 'config/app'; puts 'Aplicacion Hanami OK'"

                    if errorlevel 1 (
                        echo ERROR: La aplicacion no pudo inicializar.
                        exit /B 1
                    )
                '''
            }
        }

        stage('Run Migrations') {
            steps {
                bat '''
                    cd /D "%DEPLOY_DIR%"

                    "%RUBY_HOME%\\bin\\ruby.exe" -S bundle exec hanami db migrate

                    if errorlevel 1 (
                        echo ERROR: Fallaron las migraciones.
                        exit /B 1
                    )
                '''
            }
        }

        stage('Configure Service') { 
            steps {
        withCredentials([
            string(
                credentialsId: 'VAULT_TOKEN',
                variable: 'VAULT_TOKEN'
            )
        ]) {
            bat '''
                echo ==========================================
                echo Configuring Dash Windows service
                echo ==========================================

                "%PYTHON_HOME%\\python.exe" "%SERVICE_MANAGER%" install ^
                    "%SERVICE_ID%" ^
                    "%DEPLOY_DIR%" ^
                    --name "%SERVICE_NAME%" ^
                    --type ruby ^
                    --main "dash_erp.app:server" ^
                    --host "127.0.0.1:%PORT%" ^
                    --env "VAULT_ADDR=%VAULT_ADDR%" ^
                    --env "VAULT_TOKEN=%VAULT_TOKEN%"

                if errorlevel 1 (
                    echo ERROR: Service configuration failed
                    exit /B 1
                )
            '''
        }
            }
        }

        stage('Start Service') {
            steps {
                bat '''
                    "%PYTHON_HOME%\\python.exe" "%SERVICE_MANAGER%" start "%SERVICE_ID%"
                '''
            }
        }

        stage('Verify Service') {
            steps {
                bat '''
                    sc query "%SERVICE_ID%" | findstr /I "RUNNING"

                    if errorlevel 1 (
                        echo ERROR: El servicio no esta en ejecucion.
                        exit /B 1
                    )
                '''
            }
        }

        stage('Health Check') {
            steps {
                powershell '''
                    $url = "http://127.0.0.1:$env:PORT/$env:BASE_PATH/"
                    $maxAttempts = 10

                    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
                        Write-Host "Health check $attempt/$maxAttempts: $url"

                        try {
                            $response = Invoke-WebRequest `
                                -UseBasicParsing `
                                -Uri $url `
                                -TimeoutSec 5

                            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                                Write-Host "Hanami ERP disponible."
                                exit 0
                            }
                        }
                        catch {
                            Write-Host "Hanami ERP aun no responde."
                        }

                        Start-Sleep -Seconds 3
                    }

                    throw "Hanami ERP no respondio al health check: $url"
                '''
            }
        }
    }

    post {
        success {
            echo 'Hanami ERP desplegado correctamente.'
            echo 'URL interna: http://127.0.0.1:7781/'
        }

        failure {
            echo 'Fallo desplegando Hanami ERP.'
        }
    }
}