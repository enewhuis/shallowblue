defmodule Shallowblue.Match do
  use Shallowblue.Web, :model

  schema "matches" do
    belongs_to :player1, Shallowblue.User
    belongs_to :player2, Shallowblue.User
    field :moves, {:array, :string}, default: []
    field :finished_at, :utc_datetime, null: true
    timestamps()
  end

  def status(match) do
    cond do
      match.finished_at -> "finished"
      is_nil(match.player2_id) -> "waiting"
      true -> "playing"
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player1_id, :player2_id, :moves, :finished_at])
    |> validate_required([:player1_id])
  end
end
