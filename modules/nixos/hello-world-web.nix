{ pkgs, lib, ... }:
let
  hello-world-server = pkgs.runCommand "hello-world-server" {} ''
    mkdir -p $out/{bin,/share/webroot}
    cat > $out/share/webroot/index.html <<EOF
    <html><head><title>Hello world</title></head><body><h1>Hello World!</h1></body></html>
    EOF
    cat > $out/bin/hello-world-server <<EOF
    #!${pkgs.runtimeShell}
    exec ${lib.getExe pkgs.python3} -m http.server 8000 --dir "$out/share/webroot"
    EOF
    chmod +x $out/bin/hello-world-server
  '';
in {
  systemd.services.hello-world-server = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      DynamicUser = true;
      ExecStart = lib.getExe hello-world-server;
    };
  };

  services.caddy.virtualHosts."zenitha.duckdns.org".extraConfig = ''
      tls {
        dns duckdns b1c857b3-9f0a-4106-b618-b9e52bcbcf36
      }

      reverse_proxy localhost:8000
    '';
}