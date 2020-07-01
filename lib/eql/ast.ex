defprotocol EQL.AST do
  @moduledoc false

  # credo:disable-for-next-line Credo.Check.Design.TagFIXME
  # FIXME: change return to {:ok, EQL.expr} | {:error, EQL.Error.t}
  @spec to_expr(t) :: EQL.expr()
  def to_expr(node)
end
