defmodule DigraphExamples do
  @moduledoc false

  use Boundary, ignore?: true

  @inspect_opts [pretty: true, limit: :infinity, printable_limit: :infinity]

  def pp(term) do
    # credo:disable-for-next-line Credo.Check.Warning.IoInspect
    IO.inspect(term, @inspect_opts)
  end

  def index(resolvers) do
    dg = :digraph.new()
    Digraph.index(resolvers, dg)
  end

  def simple_index(), do: index(simple_resolvers())
  def complex_index(), do: index(complex_resolvers())
  def xen_index(), do: index(xen_resolvers())

  def simple_resolvers() do
    [
      Digraph.resolver(
        :"get-started/latest-product",
        [],
        [%{:"get-started/latest-product" => [:"product/id", :"product/title", :"product/price"]}]
      ),
      Digraph.resolver(
        :"get-started/product-brand",
        [:"product/id"],
        [:"product/brand"]
      ),
      Digraph.resolver(
        :"get-started/brand-id-from-name",
        [:"product/brand"],
        [:"product/brand-id"]
      ),
      Digraph.resolver(
        :"get-started/widget",
        [:"product/brand-id", :"user/id"],
        [:"widget/description", :"widget/id"]
      )
    ]
  end

  def complex_resolvers() do
    [
      %{id: :r1, input: [:a], output: [:b]},
      %{id: :r2, input: [:c], output: [:d]},
      %{id: :r3, input: [:c], output: [:e]},
      %{id: :r4, input: [:e], output: [:l]},
      %{id: :r5, input: [:l], output: [:m]},
      %{id: :r6, input: [:l], output: [:n]},
      %{id: :r7, input: [:n], output: [:o]},
      %{id: :r8, input: [:m], output: [:p]},
      %{id: :r9, input: [:o], output: [:p]},
      %{id: :r10, input: [:g], output: [:k]},
      %{id: :r11, input: [:h], output: [:g]},
      %{id: :r12, input: [:i], output: [:h]},
      %{id: :r13, input: [:j], output: [:i]},
      %{id: :r14, input: [:g], output: [:j]},
      %{id: :r15, input: [:b, :d], output: [:f]},
      %{id: :r16, input: [:q], output: [:r]},
      %{id: :r17, input: [:t], output: [:v]},
      %{id: :r18, input: [:u], output: [:v]},
      %{id: :r19, input: [:v], output: [:w]},
      %{id: :r20, input: [:r, :w], output: [:s]},
      %{id: :r21, input: [:s], output: [:y]},
      %{id: :r22, input: [:y], output: [:z]},
      %{id: :r23, input: [:z], output: [:o]},
      %{id: :r24, input: [:aa], output: [:ab]},
      %{id: :r25, input: [:ab], output: [:z]},
      %{id: :r26, input: [:ac], output: [:y]},
      %{id: :r27, input: [:ad], output: [:ac]},
      %{id: :r28, input: [:ae], output: [:ad]},
      %{id: :r29, input: [:ae], output: [:af]},
      %{id: :r30, input: [:af], output: [:ab]},
      %{id: :r31, input: [:ad], output: [:ab]},
      %{id: :r32, input: [:f], output: [:k]},
      %{id: :r33, input: [:k], output: [:p]}
    ]
  end

  def xen_resolvers() do
    [
      Digraph.resolver(
        :"citrix.xapi.vm/get-record",
        [:"citrix.xapi.vm/opaque-reference"],
        [
          :"citrix.xapi.vm/uuid",
          %{:"citrix.xapi.vm/vbds" => [:"citrix.xapi.vbd/opaque-reference"]},
          %{:"citrix.xapi.vm/vifs" => [:"citrix.xapi.vif/opaque-reference"]},
          :"citrix.xapi.vm/name-description",
          :"citrix.xapi.vm/name-label",
          :"citrix.xapi.vm/tags"
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.vm/get-by-name-label",
        [:"citrix.xapi.vm/name-label"],
        [:"citrix.xapi.vm/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vm/get-by-uuid",
        [:"citrix.xapi.vm/uuid"],
        [:"citrix.xapi.vm/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vm/get-all",
        [],
        [%{:"citrix.xapi.vm/all" => [:"citrix.xapi.vm/opaque-reference"]}]
      ),
      Digraph.resolver(
        :"citrix.xapi.vif/get-record",
        [:"citrix.xapi.vif/opaque-reference"],
        [
          :"citrix.xapi.vif/uuid",
          :"citrix.xapi.vif/mac",
          :"citrix.xapi.vif/device",
          :"citrix.xapi.vif/currently-attached",
          :"citrix.xapi.vif/mtu",
          %{:"citrix.xapi.vif/vm" => [:"citrix.xapi.vm/opaque-reference"]},
          %{:"citrix.xapi.vif/network" => [:"citrix.xapi.network/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.vif/get-by-uuid",
        [:"citrix.xapi.vif/uuid"],
        [:"citrix.xapi.vif/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vif/get-all",
        [],
        [:"citrix.xapi.vif/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.network/get-record",
        [:"citrix.xapi.network/opaque-reference"],
        [
          :"citrix.xapi.network/uuid",
          :"citrix.xapi.network/mtu",
          %{:"citrix.xapi.network/vifs" => [:"citrix.xapi.vif/opaque-reference"]},
          %{:"citrix.xapi.network/pifs" => [:"citrix.xapi.pif/opaque-reference"]},
          :"citrix.xapi.network/bridge",
          :"citrix.xapi.network/name-description",
          :"citrix.xapi.network/name-label",
          :"citrix.xapi.network/tags"
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.network/get-by-name-label",
        [:"citrix.xapi.network/name-label"],
        [:"citrix.xapi.network/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.network/get-by-uuid",
        [:"citrix.xapi.network/uuid"],
        [:"citrix.xapi.network/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.network/get-all",
        [],
        [:"citrix.xapi.network/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.pif/get-record",
        [:"citrix.xapi.pif/opaque-reference"],
        [
          :"citrix.xapi.pif/uuid",
          :"citrix.xapi.pif/mac",
          :"citrix.xapi.pif/mtu",
          :"citrix.xapi.pif/dns",
          :"citrix.xapi.pif/ip",
          :"citrix.xapi.pif/vlan",
          %{:"citrix.xapi.pif/host" => [:"citrix.xapi.host/opaque-reference"]},
          %{:"citrix.xapi.pif/network" => [:"citrix.xapi.network/opaque-reference"]},
          %{:"citrix.xapi.pif/bond-master-of" => [:"citrix.xapi.bond/opaque-reference"]},
          %{:"citrix.xapi.pif/bond-slave-of" => [:"citrix.xapi.bond/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.pif/get-by-uuid",
        [:"citrix.xapi.pif/uuid"],
        [:"citrix.xapi.pif/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.pif/get-all",
        [],
        [:"citrix.xapi.pif/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vbd/get-record",
        [:"citrix.xapi.vbd/opaque-reference"],
        [
          :"citrix.xapi.vbd/uuid",
          :"citrix.xapi.vbd/device",
          %{:"citrix.xapi.vbd/vdi" => [:"citrix.xapi.vdi/opaque-reference"]},
          %{:"citrix.xapi.vbd/vm" => [:"citrix.xapi.vm/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.vbd/get-by-uuid",
        [:"citrix.xapi.vbd/uuid"],
        [:"citrix.xapi.vbd/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vbd/get-all",
        [],
        [:"citrix.xapi.vbd/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vdi/get-record",
        [:"citrix.xapi.vdi/opaque-reference"],
        [
          :"citrix.xapi.vdi/uuid",
          :"citrix.xapi.vdi/location",
          :"citrix.xapi.vdi/name-description",
          :"citrix.xapi.vdi/name-label",
          %{:"citrix.xapi.vdi/parent" => [:"citrix.xapi.vdi/opaque-reference"]},
          %{:"citrix.xapi.vdi/sr" => [:"citrix.xapi.sr/opaque-reference"]},
          %{:"citrix.xapi.vdi/vbds" => [:"citrix.xapi.vbd/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.vdi/get-by-name-label",
        [:"citrix.xapi.vdi/name-label"],
        [:"citrix.xapi.vdi/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vdi/get-by-uuid",
        [:"citrix.xapi.vdi/uuid"],
        [:"citrix.xapi.vdi/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.vdi/get-all",
        [],
        [:"citrix.xapi.vdi/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.sr/get-record",
        [:"citrix.xapi.sr/opaque-reference"],
        [
          :"citrix.xapi.sr/uuid",
          :"citrix.xapi.sr/tags",
          :"citrix.xapi.sr/name-description",
          :"citrix.xapi.sr/name-label",
          %{:"citrix.xapi.sr/vdis" => [:"citrix.xapi.vdi/opaque-reference"]},
          %{:"citrix.xapi.sr/pbds" => [:"citrix.xapi.pbd/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.sr/get-by-name-label",
        [:"citrix.xapi.sr/name-label"],
        [:"citrix.xapi.sr/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.sr/get-by-uuid",
        [:"citrix.xapi.sr/uuid"],
        [:"citrix.xapi.sr/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.sr/get-all",
        [],
        [:"citrix.xapi.sr/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.pbd/get-record",
        [:"citrix.xapi.pbd/opaque-reference"],
        [
          :"citrix.xapi.pbd/uuid",
          :"citrix.xapi.pbd/currently-attached",
          %{:"citrix.xapi.pbd/host" => [:"citrix.xapi.host/opaque-reference"]},
          %{:"citrix.xapi.pbd/sr" => [:"citrix.xapi.sr/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.pbd/get-by-uuid",
        [:"citrix.xapi.pbd/uuid"],
        [:"citrix.xapi.pbd/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.pbd/get-all",
        [],
        [:"citrix.xapi.pbd/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.host/get-record",
        [:"citrix.xapi.host/opaque-reference"],
        [
          :"citrix.xapi.host/uuid",
          :"citrix.xapi.host/enabled",
          :"citrix.xapi.host/hostname",
          :"citrix.xapi.host/name-label",
          :"citrix.xapi.host/name-description",
          :"citrix.xapi.host/tags",
          :"citrix.xapi.host/address",
          %{:"citrix.xapi.host/pbds" => [:"citrix.xapi.pbd/opaque-reference"]},
          %{:"citrix.xapi.host/pifs" => [:"citrix.xapi.pif/opaque-reference"]},
          %{:"citrix.xapi.host/control-domain" => [:"citrix.xapi.vm/opaque-reference"]},
          %{:"citrix.xapi.host/resident-vms" => [:"citrix.xapi.vm/opaque-reference"]},
          %{:"citrix.xapi.host/uuid" => [:"citrix.xapi.host/opaque-reference"]},
          %{:"citrix.xapi.host/local-cache-sr" => [:"citrix.xapi.sr/opaque-reference"]},
          %{:"citrix.xapi.host/suspend-image-sr" => [:"citrix.xapi.sr/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.host/get-by-name-label",
        [:"citrix.xapi.host/name-label"],
        [:"citrix.xapi.host/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.host/get-by-uuid",
        [:"citrix.xapi.host/uuid"],
        [:"citrix.xapi.host/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.host/get-all",
        [],
        [:"citrix.xapi.host/opaque-reference"]
      ),
      Digraph.resolver(
        :"citrix.xapi.session/get-record",
        [:"citrix.xapi.session/opaque-reference"],
        [
          :"citrix.xapi.session/uuid",
          :"citrix.xapi.session/last-active",
          :"citrix.xapi.session/validation-time",
          :"citrix.xapi.session/originator",
          %{:"citrix.xapi.session/parent" => [:"citrix.xapi.session/opaque-reference"]},
          %{:"citrix.xapi.session/tasks" => [:"citrix.xapi.task/opaque-reference"]},
          %{:"citrix.xapi.session/this-host" => [:"citrix.xapi.host/opaque-reference"]},
          %{:"citrix.xapi.session/this-user" => [:"citrix.xapi.user/opaque-reference"]}
        ]
      ),
      Digraph.resolver(
        :"citrix.xapi.session/get-by-uuid",
        [:"citrix.xapi.session/uuid"],
        [:"citrix.xapi.session/opaque-reference"]
      )
    ]
  end
end
