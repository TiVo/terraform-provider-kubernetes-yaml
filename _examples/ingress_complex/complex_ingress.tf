resource "kubernetes_secret" "gitlfs_tls" {
  metadata {
    name      = "name-here"
  }

  data = map(
    "tls.crt", "somedata",
    "tls.key", "moredata"
  )
}

resource "k8sraw_yaml" "test" {
  yaml_body = <<YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/affinity: cookie
    nginx.ingress.kubernetes.io/proxy-body-size: 0m
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: name-here
spec:
  rules:
    - host: bob
      http:
        paths:
          - path: /
            backend:
              serviceName: jerry
              servicePort: 80
  tls:
    - secretName: name-here
      hosts:
      - bob
YAML
}
