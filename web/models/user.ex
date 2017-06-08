defmodule Shallowblue.User do
  use Shallowblue.Web, :model

  schema "users" do
    field :fullname, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fullname])
    |> validate_required([:fullname])
  end
end
