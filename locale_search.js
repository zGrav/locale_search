'use strict';

let langFile = require(process.argv[2]);
let keyToSearch = process.argv[3];

let DOT_SEPARATOR = ".";
let _ = require('lodash');

let deleteKeysFromObject = function (object, keys, options) {
  let keysToDelete;

  // deep copy by default
  let isDeep = true;

  // to preserve backwards compatibility, assume that only explicit options means shallow copy
  if (_.isUndefined(options) == false) {
    if (_.isBoolean(options.copy)) {
      isDeep = options.copy;
    }
  }

  // do not modify original object if copy is true (default)
  let finalObject;
  if (isDeep) {
    finalObject = _.clone(object, isDeep);
  } else {
    finalObject = object;
  }

  if (typeof finalObject === 'undefined') {
    throw new Error('undefined is not a valid object.');
  }
  if (arguments.length < 2) {
    throw new Error("provide at least two parameters: object and list of keys");
  }

  // collect keys
  if (Array.isArray(keys)) {
    keysToDelete = keys;
  } else {
    keysToDelete = [keys];
  }

  keysToDelete.forEach(function(elem) {
    for(let prop in finalObject) {
      if(finalObject.hasOwnProperty(prop)) {
        if (elem === prop) {
          // simple key to delete
          delete finalObject[prop];
        } else if (elem.indexOf(DOT_SEPARATOR) != -1) {
          let parts = elem.split(DOT_SEPARATOR);
          let pathWithoutLastEl;

          let lastAttribute;

          if (parts && parts.length === 2) {

            lastAttribute = parts[1];
            pathWithoutLastEl = parts[0];
            let nestedObjectRef = finalObject[pathWithoutLastEl];
            if (nestedObjectRef) {
              delete nestedObjectRef[lastAttribute];
            }
          } else if (parts && parts.length === 3) {
            // last attribute is the last part of the parts
            lastAttribute = parts[2];
            let deepestRef = (finalObject[parts[0]])[parts[1]];
            delete deepestRef[lastAttribute];
        } else if (parts && parts.length === 4) {
            // last attribute is the last part of the parts
            lastAttribute = parts[3];
            let deepestRef = (finalObject[parts[0]])[parts[1]][parts[2]];
            delete deepestRef[lastAttribute];
        } else if (parts && parts.length === 5) {
            lastAttribute = parts[4];
            let deepestRef = (finalObject[parts[0]])[parts[1]][parts[2]][parts[3]];
            delete deepestRef[lastAttribute];
        } else {
            throw new Error("Nested level " + parts.length + " is not supported yet");
        }

        } else {
          if (_.isObject(finalObject[prop]) && !_.isArray(finalObject[prop])) {

            finalObject[prop] = deleteKeysFromObject(finalObject[prop], keysToDelete, options);
          }
        }
      }

    }
  });

  return finalObject;

};

let result = deleteKeysFromObject(langFile, [keyToSearch]);

let fs = require('fs');
fs.writeFile(process.argv[2], JSON.stringify(result, null, 2), function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
});
