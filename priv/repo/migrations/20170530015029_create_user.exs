defmodule Shallowblue.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :fullname, :string

      timestamps()
    end

  end
end
