class GraphQLQueries {
  static final eventSearchQuery = r'''
      query EventLinkQuery($query: String!, $filter: String!) {
        searchEvents(query: $query, filter: $filter) {
          id
          name
          description
          url
          sales {
            startDateTime
            endDateTime
          }
          venues {
            name
            address {
              line
            }
            city {
              name
            }
            country {
              name
            }
          }
          images {
            url
            width
            height
          }
          classifications {
            genre {
              name
            }
          }
          isActive
        }
      }
      ''';

  static final getUserByEmailQuery = r'''
        query EventLinkQuery($email: String!) {
          userByEmail(email: $email) {
            id
            accountType
            loginMethod
            picUrl
            firstName
            middleName
            lastName
            fullName
            email
            address
            birthdate
            hashedPassword
            phoneNumber
            country
            participatingEvents
            favoriteEvents
            pastEvents
            buddies
            payments
            lastActivityDate
            isActive
            dbCreatedDate
            dbModifiedDate
            dbDeletedDate
            dbReactivatedDate
            isDeleted
          }
        }
        ''';

  static final getUserByIdQuery = r'''
        query EventLinkQuery($userId: String!) {
          user(userId: $userIda) {
            id
            accountType
            loginMethod
            picUrl
            firstName
            middleName
            lastName
            fullName
            email
            address
            birthdate
            hashedPassword
            phoneNumber
            country
            participatingEvents
            favoriteEvents
            pastEvents
            buddies
            payments
            lastActivityDate
            isActive
            dbCreatedDate
            dbModifiedDate
            dbDeletedDate
            dbReactivatedDate
            isDeleted
          }
        }
        ''';

  static final createUserMutation = r'''
    mutation EventLinkMutation($userInput: UserCreateInput!) {
      createUser(userInput: $userInput) {
        fullName
      }
    }
     ''';

  static final addFavoriteEventMutation = r'''
    mutation EventLinkMutation($userId: String!, $eventId: String!) {
      addFavoriteEvent(userId: $userId, eventId: $eventId)
    }''';

  static final removeFavoriteEventMutation = r'''
    mutation EventLinkMutation($userId: String!, $eventId: String!) {
      removeFavoriteEvent(userId: $userId, eventId: $eventId)
    }''';

  static final participatingBuddiesQuery = r'''
    query EventLinkQuery($userId: String!, $eventId: String!) {
      participatingBuddies(userId: $userId, eventId: $eventId) {
        fullName
      }
    }
    ''';

  static final getBuddiesQuery = r'''
  query EventLinkQuery($userId: String!) {
    buddies(userId: $userId) {
            id
            accountType
            loginMethod
            picUrl
            firstName
            middleName
            lastName
            fullName
            email
            address
            birthdate
            hashedPassword
            phoneNumber
            country
            participatingEvents
            favoriteEvents
            pastEvents
            buddies
            payments
            lastActivityDate
            isActive
            dbCreatedDate
            dbModifiedDate
            dbDeletedDate
            dbReactivatedDate
            isDeleted
    }
  }
  ''';

  static final addBuddyMutation = r'''
  mutation EventLinkMutation($userId: String!, $buddyId: String!) {
    addBuddy(userId: $userId, buddyId: $buddyId)
  }
  ''';

  static final removeBuddyMutation = r'''
  mutation EventLinkMutation($userId: String!, $buddyId: String!) {
    removeBuddy(userId: $userId, buddyId: $buddyId)
  }
  ''';

  static final addParticipatingEventMutation = r'''
  mutation EventLinkMutation($userId: String!, $eventId: String!) {
    addParticipatingEvent(userId: $userId, eventId: $eventId)
  }
  ''';

  static final removeParticipatingEventMutation = r'''
  mutation EventLinkMutation($userId: String!, $eventId: String!) {
    removeParticipatingEvent(userId: $userId, eventId: $eventId)
  }
  ''';

  static final uploadProfilePictureMutation = r'''
  mutation EventLinkMutation($userId: String!, $imageData: String!) {
    uploadProfilePicture(userId: $userId, imageData: $imageData)
  }
  ''';

  static final updateUserMutation = r'''
  mutation EventLinkMutation($userInput: UserUpdateInput!) {
    updateUser(userInput: $userInput) {
      fullName
    }
  }
  ''';

  static final searchUsersQuery = r'''
  query EventLinkQuery($query: String!) {
    searchUsers(query: $query) {
      id
      picUrl
      email
      fullName
      isActive
      loginMethod
    }
  }
  ''';

  static final searchUsersIdsQuery = r'''
  query EventLinkQuery($query: String!) {
    searchUsers(query: $query) {
     id
     loginMethod
    }
  }
  ''';
}
