class Post < ApplicationRecord

  # Add rich text field for the blog posts' body text
  has_rich_text :body

  # Require title, author, and body
  validates :title, :author, :body, presence: true

  # Gross scope with a raw SQL inner join, joining on one pair of dynamic columns and two pairs of hard-coded columns
  scope :with_rich_texts, -> { joins("INNER JOIN action_text_rich_texts ON posts.id = action_text_rich_texts.record_id AND 'body' = action_text_rich_texts.name AND 'Post' = action_text_rich_texts.record_type") }

  # Simple search using a SQL where clause
  def self.search_where(query)
    query = "%#{query.downcase}%"

    # Works but doesn't include body in the search scope
    #Post.where('lower(title) like ? OR lower(author) like ?', query, query)

    # Error: SQLite3::SQLException: no such column: body
    #Post.where('lower(title) like ? OR lower(author) like ? or lower(body) like ?', query, query, query)

    # Error: SQLite3::SQLException: no such column: body
    #Post.includes(:action_text_rich_texts).where('lower(title) like ? OR lower(author) like ? or lower(body) like ?', query, query, query)

    # Is this really the best option??
    Post.with_rich_texts.where('lower(title) like ? OR lower(author) like ? or lower(body) like ?', query, query, query)
  end

end
