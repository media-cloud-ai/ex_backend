# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "technician@media-cloud.ai", password: "mediacloudai", roles: ["technician"], first_name: "MCAI", last_name: "Technician", username: "technician"},
  %{email: "editor@media-cloud.ai", password: "mediacloudai", roles: ["editor"], first_name: "MCAI", last_name: "Editor", username: "editor"}
]

for attrs <- users do
  {:ok, user} = ExBackend.Accounts.create_user(attrs)
  ExBackend.Accounts.update_password(user, attrs)
  ExBackend.Accounts.confirm_user(user)
end

admin = ExBackend.Accounts.get_by(%{"email" => "admin@media-cloud.ai"})
ExBackend.Accounts.update_user(admin, %{"roles" => ["administrator"]})

Code.eval_string(EEx.eval_file("priv/repo/workflow_live.eex", uuid: admin.uuid))
Code.eval_string(EEx.eval_file("priv/repo/workflow_with_statuses.eex", uuid: admin.uuid))
Code.eval_string(EEx.eval_file("priv/repo/worker_live.eex", uuid: admin.uuid))
