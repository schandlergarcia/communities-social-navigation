/**
 * Created by stephan.garcia on 2020-04-18.
 */

public with sharing class CommunitiesNavigationMenuController {
  @AuraEnabled(Cacheable=true)
  public static List<NavigationMenuItem> getNavigationMenuItems(String menuName) {
    List<NavigationMenuItem> navigationMenuItems = [
      SELECT
        AccessRestriction,
        CreatedById,
        CreatedDate,
        DefaultListViewId,
        DraftRowId,
        Id,
        IsDeleted,
        Label,
        LastModifiedById,
        LastModifiedDate,
        NavigationLinkSetId,
        ParentId,
        Position,
        Status,
        SystemModstamp,
        Target,
        TargetPrefs,
        Type,
        NavigationLinkSet.DeveloperName
      FROM NavigationMenuItem
      WHERE NavigationLinkSet.DeveloperName = :menuName AND Status = 'Live'
      ORDER BY Position
    ];

    return navigationMenuItems;
  }

  @AuraEnabled(Cacheable=true)
  public static Map<String, Object> getConnectNavigationItems(String menuName) {
    String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();

    String networkId = Network.getNetworkId();

    List<NavigationLinkSet> navigationLinkSets = [SELECT Id FROM NavigationLinkSet WHERE DeveloperName = :menuName LIMIT 1];
    NavigationLinkSet navigationLinkSet = (navigationLinkSets.size() == 1) ? navigationLinkSets.get(0) : null;

    String restAPIURL =
      baseUrl +
      '/services/data/v48.0/connect/communities/' +
      networkId +
      '/navigation-menu/navigation-menu-items?navigationLinkSetId=' +
      navigationLinkSet.Id +
      '&includeImageUrl=true&addHomeMenuItem=false';

    // Build the HttpRequest
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setMethod('GET');

    // Validate against the current users sessionId --
    httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
    httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    httpRequest.setEndpoint(restAPIURL);

    //String navigationItems = '';

    Map<String, Object> navigationItems = new Map<String, Object>();

    try {
      Http http = new Http();

      HttpResponse httpResponse = http.send(httpRequest);

      if (httpResponse.getStatusCode() == 200) {
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());

        navigationItems = response;

        System.debug('Response: ' + navigationItems);
      } else {
        System.debug(' httpResponse ' + httpResponse.getBody());

        throw new CalloutException(httpResponse.getBody());
      }

      return navigationItems;
    } catch (System.Exception e) {
      System.debug('ERROR: ' + e);

      throw e;
    }
  }
}
