[
  {
    $project: {
      user: {
        $map: {
          input: {
            $objectToArray:
              "$supplemental_data.users",
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
        user: 1,
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
        path: "$user",
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$user.id",
        first_name: {
          $first: "$user.first_name",
        },
        last_name: {
          $first: "$user.last_name",
        },
        username: {
          $first: "$user.username",
        },
        employee_number: {
          $first: "$user.employee_number",
        },
      },
  },
  {
    $sort:
      /**
       * Provide any number of field/order pairs.
       */
      {
        _id: 1,
      },
  },
  {
    $out:
      /**
       * Provide the name of the output collection.
       */
      "Users",
  },
]