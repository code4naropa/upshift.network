module PrivateConversationsHelper

  # returns an array of participants without the current user
  def get_participants_without_current_user participants
    participants_without_current_user =
      participants.to_a.map { |p| p unless p.id == @current_user.id } - [nil]
  end

  # lists the names of participants in a conversation (without the current user)
  def list_participants participants

    # do not display current user on participant list
    participants_without_current_user =
      get_participants_without_current_user participants

    # list the names
    names_of_participants = participants_without_current_user.pluck(:name)

    # return in sentence style
    return names_of_participants.to_sentence
  end

  # generates the link to a private conversation:
  # - uses username if single recipient
  # - uses ID if multiple recipients
  def link_to_private_conversation private_conversation

    # do not display current user on participant list
    participants_without_current_user =
      get_participants_without_current_user private_conversation.participants

    # we have only one user, so let's use their username
    if participants_without_current_user.size == 1
      return private_conversation_path(participants_without_current_user.pluck(:username).first)
    end

    # return the standard path using ID
    return private_conversation_path(private_conversation)
  end

  # shows a preview of the conversation by showing its first messages
  def show_conversation_preview private_conversation
    if private_conversation.most_recent_message
      return truncate(private_conversation.most_recent_message.content)
    else
      return "No messages yet."
    end
  end

end
