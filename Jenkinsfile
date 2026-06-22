pipeline {
    agent { label 'windows-agent' } // Ejecuta los pasos en la máquina Windows local (agente)

    stages {
        stage('Restaurar Paquetes NuGet') {
            steps {
                bat 'nuget.exe restore Monolito.slnx'
            }
        }
        stage('Compilar Solución') {
            steps {
                bat '"C:\\Program Files\\Microsoft Visual Studio\\18\\Insiders\\MSBuild\\Current\\Bin\\MSBuild.exe" Monolito.slnx /p:Configuration=Release /t:Build'
            }
        }
        stage('Ejecutar Pruebas') {
            steps {
                bat '"C:\\Program Files\\Microsoft Visual Studio\\18\\Insiders\\Common7\\IDE\\Extensions\\TestPlatform\\vstest.console.exe" Monolito.Tests\\bin\\Release\\net481\\Monolito.Tests.dll'
            }
        }
        stage('Publicar Aplicación') {
            steps {
                bat '"C:\\Program Files\\Microsoft Visual Studio\\18\\Insiders\\MSBuild\\Current\\Bin\\MSBuild.exe" Monolito\\Monolito.csproj /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl="%WORKSPACE%\\publish" /p:DeployDefaultTarget=WebPublish /p:WebPublishMethod=FileSystem /p:DeleteExistingFiles=True'
            }
        }
        stage('Desplegar en IIS') {
            steps {
                bat 'powershell -Command "New-Item -ItemType Directory -Force -Path C:\\inetpub\\wwwroot\\Monolito; Copy-Item -Path \'%WORKSPACE%\\publish\\*\' -Destination C:\\inetpub\\wwwroot\\Monolito -Recurse -Force"'
            }
        }
    }
}
