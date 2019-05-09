defmodule PeerInterface do
    def execute(["WANT", fileId]) do
        case File.read(Utils.param(:files)<>fileId) do
        {:ok, file} -> file
        _ -> "NO DISPONIBLE"
        end
    end

    def execute(_), do: "FORMAT INCORRECT"
end
