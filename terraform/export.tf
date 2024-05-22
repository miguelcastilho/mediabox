resource "local_file" "tf_ansible_vars" {
  content = templatefile("${path.module}/templates/tf_ansible_vars.yml.tpl", {
    cf_tunnel_id  = cloudflare_tunnel.mediabox.id
    cf_account_id    = var.cloudflare_account_id
    cf_tunnel_name = cloudflare_tunnel.mediabox.name
    cf_tunnel_secret     = random_id.tunnel_secret.b64_std
  })

  filename = "../ansible/tf_ansible_vars.yml"
}
