module Snoo
  # Wiki related methods, such as manipulating and reading pages, revisions and
  # discussions
  #
  # @author Horse M.D.
  module Wiki
    
    # Retrieve a list of wiki pages in this subreddit
    #
    # @param subreddit [String] The subreddit to fetch from.
    # @return [Hash] TODO   
    def get_pages subreddit
      read_wiki_response(get("/r/#{subreddit}/wiki/pages"))
    end

    # Retrieve the current permission settings for the given page
    #
    # @param subreddit [String] The subreddit to fetch from.
    # @param page [String] The name of an existing wiki page.
    # @return [Hash] TODO   
    def get_settings subreddit, page
      read_wiki_response(get("/r/#{subreddit}/wiki/settings/#{page}"))
    end

    # Retrieve a list of discussions about this wiki page
    #
    # @param subreddit [String] The subreddit to fetch from.
    # @param page [String] The name of an existing wiki page.
    # @option opts [String] :before The "fullname" of a thing.
    # @option opts [String] :after The "fullname" of a thing.
    # @option opts [Fixnum] :count A positive integer (default: 0).
    # @option opts [Fixnum] :limit (100) The number to get. Can't be higher than 100.
    # @option opts [String] :show The string 'all'
    def get_discussions subreddit, page, opts={}
      options = {
        limit: 100
      }.merge opts
      read_wiki_response(get("/r/#{subreddit}/wiki/discussions/#{page}", query: options))
    end

    # Retrieve a list of wiki revisions for this subreddit
    # 
    # @param subreddit [String] The subreddit to fetch from.
    # @param page [String] If present, return a list of revisions of this wiki page.
    # @option opts [String] :before The "fullname" of a thing.
    # @option opts [String] :after The "fullname" of a thing.
    # @option opts [Fixnum] :count A positive integer (default: 0).
    # @option opts [Fixnum] :limit (100) The number to get. Can't be higher than 100.
    # @option opts [String] :show The string 'all'
    def get_revisions subreddit, opts={}
      options = {
        limit: 100
      }.merge opts

      page = options.delete(:page) || ''

      # TODO: we can probably return something nicer than a nokogiri object
      # relevant css elements are .diff_next and .diff_chg

      read_wiki_response(get("/r/#{subreddit}/wiki/revisions/#{page}", query: options))
    end

    # Retrieve the contents of the given page
    # If v and v2 are supplied, a diff between the two will be returned.
    # 
    # Because Reddit doesn't have a real API, we have to make do with returning
    # the most specific HTML as possible.
    #
    # @param subreddit [String] The subreddit to fetch from.
    # @param page [String] The name of the page to fetch.
    # @option opts [String :v A wiki revision ID.
    # @option opts [String :v2 A wiki revision ID.
    # @return [Nokogiri::XML::Element] A nokogiri XML element representing the contents of the page.
    def get_page subreddit, page, opts={}
      read_wiki_response(get("/r/#{subreddit}/wiki/#{page}", query: opts))
    end

    private
    # Because Reddit doesn't have a proper API, the only thing we can really
    # do is filter out as much junk as possible from the responses.
    # 
    # Because we're handling responses relating to Wikis - whose markup
    # may be important to the user (links, formatting etc) - we are forced to
    # offload HTML to the user :(
    #
    # read_wiki_response(response).children[1].text will fit a lot of peoples
    # needs, though.
    def read_wiki_response response
      Nokogiri::HTML.parse(response).css("div.wiki-page-content.md-container")
    end
    
  end
end
