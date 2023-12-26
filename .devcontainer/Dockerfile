ARG VARIANT="dev-debian"
#FROM mcr.microsoft.com/devcontainers/universal:${VARIANT} 
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

# [Choice] .NET version: 6.0-focal, 3.1-focal
#ARG VARIANT="6.0-focal"
#FROM mcr.microsoft.com/vscode/devcontainers/dotnet:${VARIANT}

# [Choice] Node.js version: none, lts/*, 18, 16, 14
# ARG NODE_VERSION="none"
# RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# Install SQL Tools: SQLPackage and sqlcmd
#COPY mssql/installSQLtools.sh installSQLtools.sh
#RUN bash ./installSQLtools.sh \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages you may want.
#
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install more global node packages
# RUN sudo -u node npm install -g <your-package-list-here>