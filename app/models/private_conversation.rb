class PrivateConversation < ApplicationRecord

  # # Relations
  has_many :participantships,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "private_conversation_id",
    :dependent => :destroy,
    :inverse_of => :private_conversation
  has_many :participants,
    :through => :participantships,
    :source => :participant

  # # Scopes
  default_scope -> { order('created_at ASC') }

  # finds the conversations between a set of users
  # use like PrivateConversations.find_conversations_between [alice, bob]
  scope :find_conversation_between,
    ->(users) {
      joins(participantships: :participant).
      where(users: {id: users.pluck(:id)}).
      group("id").
      having("count(\"private_conversations\".\"id\") = ?", users.size)
    }

  # # Accessors
  attr_reader(:sender, :recipient)

  # # Validations
  validates :sender, presence: true, on: :create
  validates :recipient, presence: true, on: :create
  validates :participantships,
    length: {
      is: 2,
      message: "needs exactly two conversation participants"}

  # # Methods

  def sender=(user)
    self.remove_participant @sender if @sender
    self.add_participant user
    @sender = user
  end

  def recipient=(user)
    self.remove_participant @recipient if @recipient
    self.add_participant user
    @recipient = user
  end

  protected
    # adds a participant to the conversation
    def add_participant participant
      self.participantships.build(:participant => participant)
    end

    # removes a participant from the conversation
    def remove_participant participant
      self.participantships.each do |p|
        p.mark_for_destruction if p.participant_id == participant.id
      end
    end

end
