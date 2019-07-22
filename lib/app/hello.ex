defmodule App.Hello do
  @limit_page Application.get_env(:app, :limit_page)

  def start(file_name \\ "words.txt") do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&bing_search/1)
  end

  def bing_search(word, ptr \\ 1) do
    IO.puts("[#{ptr}/#{@limit_page}] Searching: #{word}")

    "http://www.bing.com/search?q=#{word}&count=50&first=#{ptr}"
    |> HTTPotion.get
    |> IO.puts
    #|> @html
    #|> Enum.map(&save_buf/1)

    cond do
      ptr < @limit_page -> bing_search(word, ptr + 10)
      ptr == @limit_page -> IO.puts "Finished #{word}"
    end
  end

  def extract_links(html_content) do
    Floki.find(html_content, "a")
    #html_content
    #|> Floki.find("a")
    #|> Floki.attribute("href")
  end

  def save_buf(content) do
  end
end
