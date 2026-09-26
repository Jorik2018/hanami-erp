pipeline {
    agent any

    environment {
        SERVICE_ID  = 'hanami-erp'
        SERVICE_NAME = 'Hanami ERP'
        DEPLOY_DIR  = 'D:\\apps\\hanami-erp'
        PORT        = '7783'
        RUBY_HOME = 'C:\\Tools\\Ruby33-x64'

            HANAMI_ENV   = 'production'
    RACK_ENV     = 'production'
    DATA_DIR   = 'D:\\apps\\hanami-erp'
    DATABASE_URL = 'sqlite:///D:/apps/hanami-erp/hanami_erp.sqlite3'
        SQLITE_HOME = 'C:\\Tools\\sqlite'
    SQLITE_EXE  = 'C:\\Tools\\sqlite\\sqlite3.exe'
    }

    stages {
stage('Install SQLite CLI') {
    steps {
        powershell '''
            $sqliteExe = $env:SQLITE_EXE

            if (Test-Path $sqliteExe) {
                Write-Host "SQLite CLI ya esta instalado:"
                & $sqliteExe -version
                exit 0
            }

            [Net.ServicePointManager]::SecurityProtocol = `
                [Net.SecurityProtocolType]::Tls12

            $sqliteHome = $env:SQLITE_HOME
            $zipFile = Join-Path $env:TEMP "sqlite-tools.zip"
            $extractDir = Join-Path $env:TEMP "sqlite-tools"

            # SQLite 3.50.4 para Windows x64.
            $url = "https://www.sqlite.org/2025/sqlite-tools-win-x64-3500400.zip"

            if (-not (Test-Path $sqliteHome)) {
                New-Item `
                    -ItemType Directory `
                    -Path $sqliteHome `
                    -Force | Out-Null
            }

            if (Test-Path $extractDir) {
                Remove-Item `
                    -Path $extractDir `
                    -Recurse `
                    -Force
            }

            Write-Host "Descargando SQLite CLI..."
            Invoke-WebRequest `
                -UseBasicParsing `
                -Uri $url `
                -OutFile $zipFile

            Expand-Archive `
                -Path $zipFile `
                -DestinationPath $extractDir `
                -Force

            $sourceExe = Get-ChildItem `
                -Path $extractDir `
                -Filter "sqlite3.exe" `
                -Recurse |
                Select-Object -First 1

            if ($null -eq $sourceExe) {
                throw "No se encontro sqlite3.exe en el archivo descargado."
            }

            Copy-Item `
                -Path $sourceExe.FullName `
                -Destination $sqliteExe `
                -Force

            if (-not (Test-Path $sqliteExe)) {
                throw "SQLite CLI no fue instalado correctamente."
            }

            Write-Host "SQLite CLI instalado:"
            & $sqliteExe -version

            Remove-Item `
                -Path $zipFile `
                -Force `
                -ErrorAction SilentlyContinue

            Remove-Item `
                -Path $extractDir `
                -Recurse `
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

            if exist "Gemfile.lock" (
                del /F /Q "Gemfile.lock"
            )

            if exist ".bundle" (
                rmdir /S /Q ".bundle"
            )

            "%RUBY_HOME%\\bin\\ruby.exe" -S bundle config set path "vendor/bundle"
            "%RUBY_HOME%\\bin\\ruby.exe" -S bundle config set without "development test"
            "%RUBY_HOME%\\bin\\ruby.exe" -S bundle config set deployment false

            "%RUBY_HOME%\\bin\\ruby.exe" -S bundle install ^
                --jobs 4 ^
                --retry 3

            if errorlevel 1 (
                echo ERROR: No se pudieron instalar las gemas.
                exit /B 1
            )

            "%RUBY_HOME%\\bin\\ruby.exe" -S bundle lock --add-platform x64-mingw-ucrt

            if errorlevel 1 (
                echo ERROR: No se pudo generar Gemfile.lock para Windows.
                exit /B 1
            )
        '''
    }
}

stage('Generate Session Secret') {
    steps {
        script {
            env.SESSION_SECRET = powershell(
                returnStdout: true,
                script: '''
                    $bytes = New-Object byte[] 64
                    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)

                    [System.BitConverter]::ToString($bytes).Replace("-", "").ToLowerInvariant()
                '''
            ).trim()
        }
    }
}


stage('Verify Application') {
    steps {
        bat '''
            cd /D "%DEPLOY_DIR%"

            SET "PATH=%RUBY_HOME%\\bin;%PATH%"

            echo ==============================
            echo RUBY
            echo ==============================

            ruby --version
            where ruby

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

            "%RUBY_HOME%\\bin\\ruby.exe" -rbundler/setup ^
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

            SET "PATH=%RUBY_HOME%\\bin;%SQLITE_HOME%;%PATH%"

            where sqlite3

            if errorlevel 1 (
                echo ERROR: sqlite3.exe no esta disponible en PATH.
                exit /B 1
            )

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
    "%PYTHON_HOME%\\python.exe" "%SERVICE_MANAGER%" install ^
        "%SERVICE_ID%" ^
        "%DEPLOY_DIR%" ^
        --name "%SERVICE_NAME%" ^
        --description "%SERVICE_DESCRIPTION%" ^
        --type rust ^
        --executable "%RUBY_HOME%\\bin\\ruby.exe" ^
        --env "HANAMI_ENV=production" ^
        --env "RACK_ENV=production" ^
        --env "DATABASE_URL=%DATABASE_URL%" ^
        --env "SESSION_SECRET=%SESSION_SECRET%" ^
        --env "PORT=%PORT%" ^
        --env "PATH=%RUBY_HOME%\\bin;C:\\Windows\\System32;C:\\Windows" ^
        --env "VAULT_TOKEN=%VAULT_TOKEN%" ^
        --env "JWT_PUBLIC_KEY=%JWT_PUBLIC_KEY%"
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