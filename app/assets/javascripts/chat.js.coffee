$ ->
  $messageList = $("#message-list")

  if $messageList.length
    roomID = $("meta[name=room-id]").attr("content")

    eventSource = new EventSource("/room/#{roomID}/live.sse")
    eventSource.addEventListener "message", ->
      data = JSON.parse(event.data)
      $messageItem = $("<li>").text(data.body)
      $messageItem.appendTo($messageList)

    $newMessageForm = $("#new-message-form")
    $newMessageInput = $("#new-message-input")

    $newMessageForm.submit (event) ->
      event.preventDefault()

      $.ajax
        type: "POST",
        url: "/room/#{roomID}/speak"
        data: { message: { body: $newMessageInput.val() } }
        success: -> $newMessageInput.val(null)
