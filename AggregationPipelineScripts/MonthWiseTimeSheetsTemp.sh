[
  {
    $project: {
      timesheets: {
        $map: {
          input: {
            $objectToArray: "$results.timesheets",
          },
          in: "$$this.v",
        },
      },
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
        path: "$timesheets",
      },
  },
  {
    $addFields:
      /**
       * newField: The new field name.
       * expression: The new field expression.
       */
      {
        month: {
          $substr: ["$timesheets.date", 5, 2],
        },
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$month",
        timesheets: {
          $push: "$timesheets",
        },
      },
  },
  {
    $project: {
      _id: 0,
      month: "$_id",
      timesheets: 1,
    },
  },
  // {
  //   $replaceRoot:
  //     /**
  //      * replacementDocument: A document or string.
  //      */
  //     {
  //       newRoot: {
  //         month: "$month",
  //         timesheets: "$timesheets.timesheets",
  //       },
  //     },
  // },
  {
    $out:
      /**
       * Provide the name of the output collection.
       */
      "MonthWiseTimeSheetsTemp",
  },
]