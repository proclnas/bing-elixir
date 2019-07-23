defmodule App.Hello do
  @limit_page Application.get_env(:app, :limit_page)
  @blacklist ~r/bing|microsoft|search|javascript.+|^\/|^#/

  def start(file_name \\ "words.txt") do
    case File.exists? file_name do
      false -> exit("File #{file_name} not found")
      _ -> process(file_name)
    end
  end

  def process(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&bing_search/1)
  end

  def bing_search(word, ptr \\ 1) do
    IO.puts("[#{ptr}/#{@limit_page}] Searching: #{word}")

    HTTPotion.get("http://www.bing.com/search?q=#{word}&count=50&first=#{ptr}")
    |> process_response

    cond do
      ptr < @limit_page -> bing_search(word, ptr + 10)
      ptr == @limit_page -> IO.puts "Finished #{word}"
    end
  end

  def extract_links(html_content) do
    html_content
    |> Floki.parse
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(fn(x) -> Regex.match?(@blacklist, x) == false end)
    |> Enum.map(&save_buf/1)
  end

  def process_response(%HTTPotion.Response{status_code: status_code, body: body} = resp) do
    cond do
      status_code == 200 -> extract_links(body)
      true -> {:error, resp}
    end
  end

  def save_buf(content, output \\ "output.txt") do
    case File.write(output, "#{content}\n", [:append]) do
      :ok -> IO.puts("[+] Uri saved to #{output}")
      _ -> IO.puts("[-] Error on save uri")
    end
  end
end
