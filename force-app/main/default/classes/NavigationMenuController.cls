public with sharing class NavigationMenuController {
  /**
   * getNavigationMenuItems - queries for the navigation menu items by the name the menu
   * @param menuName - the name of the requested menu
   * @return A list of navigation menu items
   */
  @AuraEnabled(Cacheable=true)
  public static List<NavigationMenuItem> getNavigationMenuItems(
    String menuName
  ) {
    List<NavigationMenuItem> navigationMenuItems = [
      SELECT
        AccessRestriction,
        Id,
        Label,
        NavigationLinkSetId,
        ParentId,
        Position,
        Status,
        Target,
        TargetPrefs,
        Type,
        NavigationLinkSet.DeveloperName
      FROM NavigationMenuItem
      WHERE NavigationLinkSet.DeveloperName = :menuName AND Status = 'Live'
      WITH SECURITY_ENFORCED
      ORDER BY Position
    ];

    return navigationMenuItems;
  }

  @AuraEnabled(Cacheable=true)
  public static Map<String, Object> getConnectNavigationItems(
    String menuName,
    String communityId
  ) {
    String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();

    List<NavigationLinkSet> navigationLinkSets = [
      SELECT Id
      FROM NavigationLinkSet
      WHERE DeveloperName = :menuName
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    NavigationLinkSet navigationLinkSet = (navigationLinkSets.size() == 1)
      ? navigationLinkSets.get(0)
      : null;

    // USe string formatters to create the callout url
    String restEndpointTemplate = '{0}/services/data/v48.0/connect/communities/{1}/navigation-menu/navigation-menu-items?navigationLinkSetId={2}&includeImageUrl=true&addHomeMenuItem=false';
    List<Object> parameters = new List<Object>{
      baseUrl,
      communityId,
      navigationLinkSet.Id
    };
    String restEndpointFormatted = String.format(
      restEndpointTemplate,
      parameters
    );

    // Build the HttpRequest
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setMethod('GET');

    // Use the current users sessionId to authorize the transaction
    // the guest user must be API enabled
    String sessionId = UserInfo.getSessionId();
    httpRequest.setHeader('Authorization', 'OAuth ' + sessionId);
    httpRequest.setHeader('Authorization', 'Bearer ' + sessionId);
    system.debug(sessionId);
    httpRequest.setEndpoint(restEndpointFormatted);

    Map<String, Object> navigationItems = new Map<String, Object>();
    try {
      Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);
      if (httpResponse.getStatusCode() == 200) {
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
          httpResponse.getBody()
        );
        navigationItems = response;
      } else {
        System.debug('ERROR: ' + httpResponse.getBody());
        throw new CalloutException(httpResponse.getBody());
      }
      return navigationItems;
    } catch (System.Exception e) {
      System.debug('ERROR: ' + e);
      throw e;
    }
  }
}
