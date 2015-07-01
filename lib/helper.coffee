showError = (error) ->
  atom.notifications.addError(error.toString(), dismissable: true)

module.exports = {showError}
