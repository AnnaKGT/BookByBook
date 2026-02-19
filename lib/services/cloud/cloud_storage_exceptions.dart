
class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateBookException extends CloudStorageExceptions{}

class CouldNotGetAllBookException extends CloudStorageExceptions{}

class CouldNotUpdateBookException extends CloudStorageExceptions{}

class CouldNotDeleteBookException extends CloudStorageExceptions{}

