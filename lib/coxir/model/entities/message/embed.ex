defmodule Coxir.Message.Embed do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  alias Coxir.Message.Embed.{Footer, Image, Thumbnail, Video, Provider, Author, Field}

  @primary_key false

  @type t :: %Embed{}

  embedded_schema do
    field(:title, :string)
    field(:type, :string)
    field(:description, :string)
    field(:url, :string)
    field(:timestamp, :utc_datetime)
    field(:color, :integer)

    embeds_one(:footer, Footer)
    embeds_one(:image, Image)
    embeds_one(:thumbnail, Thumbnail)
    embeds_one(:vdeo, Video)
    embeds_one(:provider, Provider)
    embeds_one(:author, Author)

    embeds_many(:fields, Field)
  end
end
