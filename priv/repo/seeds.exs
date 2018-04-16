# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "maarnaud@media-io.com", password: "marcantoine"},
  %{email: "valentin.noel@media-io.com", password: "valentin"}
]

for user <- users do
  {:ok, user} = ExSubtilBackend.Accounts.create_user(user)
  ExSubtilBackend.Accounts.confirm_user(user)
end
