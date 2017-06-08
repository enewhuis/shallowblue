defmodule Shallowblue.Repo.Migrations.CreateMatch do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :player1_id, references(:users, on_delete: :nothing)
      add :player2_id, references(:users, on_delete: :nothing)
      add :moves, {:array, :string}
      add :finished_at, :utc_datetime, null: true

      timestamps()
    end
    create index(:matches, [:player1_id])
    create index(:matches, [:player2_id])

  end
end
