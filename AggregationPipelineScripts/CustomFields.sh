[
  {
    $project: {
      customfield: {
        $map: {
          input: {
            $objectToArray:
              "$supplemental_data.customfields",
          },
          in: "$$this.v",
        },
      },
    },
  },
  {
    $project:
      /**
       * specifications: The fields to
       *   include or exclude.
       */
      {
        customfield: 1,
        _id: 0,
      },
  },
  {
    $unwind:
      /**
       * path: Path to the array field.
       * includeArrayIndex: Optional name for index.
       * preserveNullAndEmptyArrays: Optional
       *   toggle to unwind null and empty values.
       */
      {
        path: "$customfield",
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$customfield.id",
        name: {
          $first: "$customfield.name",
        },
        type: {
          $first: "$customfield.type",
        },
      },
  },
  {
    $sort:
      /**
       * Provide any number of field/order pairs.
       */
      {
        _id: -1,
      },
  },
  {
    $out:
      /**
       * Provide the name of the output collection.
       */
      "customfield",
  },
]