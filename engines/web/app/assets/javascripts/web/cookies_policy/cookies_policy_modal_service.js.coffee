angular.module('Darkswarm').factory "CookiesPolicyModalService", (Navigation, $modal, $location)->

  new class CookiesPolicyModalService
    defaultPath: "/policies/cookies"
    modalMessage: null

    constructor: ->
      if @isEnabled()
        @open ''

    open: (path = false, template = '/angular-templates/cookies_policy.html') =>
      @modalInstance = $modal.open
        templateUrl: template
        windowClass: "cookies-policy-modal medium"

      selectedPath = path || @defaultPath
      Navigation.navigate selectedPath

    isEnabled: =>
      $location.path() is @defaultPath || location.pathname is @defaultPath
