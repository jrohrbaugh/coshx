require "spec_helper"
describe "posts/feed.atom.builder" do

  before :each do
    assign(:title, "Some Title")
    @posts = [build(:post, :posted_on => DateTime.new(2013, 1, 1)), build(:post)]
    assign(:posts, @posts)
    assign(:feed_url, 'http://www.coshx.com/feed')
    render
    @feed_doc = Nokogiri.parse(rendered)
  end

  describe "the feed" do
    it "displays the title of the blog" do
      @feed_doc.at_css('title').content.should == "Some Title"
    end

    it "is updated at the post date of the most recent blog post" do
      @feed_doc.at_css('updated').content.should match /2013/
    end
  end

  describe "each post" do
    it "displays the author of the blog post" do
      @feed_doc.at_css('author').content.should == @posts.first.author.name
    end

    it "creates an entry for each post" do
      @feed_doc.css('entry').size.should == 2
    end

    it "contains the content of each post" do
      @feed_doc.at_css('content').content.should == @posts.first.body_html
    end
  end
end
