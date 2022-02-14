# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "technician@media-cloud.ai", password: "technician", roles: ["technician"]},
  %{email: "editor@media-cloud.ai", password: "editor", roles: ["editor"]}
]

for user <- users do
  {:ok, user} = ExBackend.Accounts.create_user(user)
  ExBackend.Accounts.confirm_user(user)
end

admin = ExBackend.Accounts.get_by(%{"email" => "admin@media-cloud.ai"})
ExBackend.Accounts.update_user(admin, %{"roles" => ["administrator", "technician", "editor"]})

Code.eval_file("priv/repo/workflow_live.exs")
Code.eval_file("priv/repo/workflow_with_statuses.exs")
Code.eval_file("priv/repo/worker_live.exs")
