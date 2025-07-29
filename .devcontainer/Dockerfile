FROM swift:5.10.1

ARG UBUNTU_PORTS="free.nchc.org.tw"
RUN sed -i.org -e "s|ports.ubuntu.com|${UBUNTU_PORTS}|g" /etc/apt/sources.list

RUN useradd -m vscode
RUN mkdir -p /home/vscode/app
RUN chown -R vscode:vscode /home/vscode/app

RUN git clone https://github.com/realm/SwiftLint.git /swiftLint
WORKDIR /swiftLint
RUN git checkout tags/0.57.0 
RUN swift build -c release
RUN cp .build/release/swiftlint /usr/local/bin/
RUN swiftlint --version
WORKDIR /
RUN rm -rf /swiftLint

USER vscode
WORKDIR /home/vscode/app
