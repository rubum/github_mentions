defmodule GitHub do
    use HTTPoison.Base
  
    @endpoint "https://api.github.com"
  
    def process_url(url) do
      @endpoint <> url
    end
  end