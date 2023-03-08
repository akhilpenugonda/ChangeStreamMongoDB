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
    $addFields: {
      month: {
        $let: {
          vars: {
            months: [
              null,
              "January",
              "February",
              "March",
              "April",
              "May",
              "June",
              "July",
              "August",
              "September",
              "October",
              "November",
              "December",
            ],
          },
          in: {
            $arrayElemAt: [
              "$$months",
              {
                $toInt: {
                  $substr: [
                    "$timesheets.date",
                    5,
                    2,
                  ],
                },
              },
            ],
          },
        },
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
    $group: {
      _id: {
        month: "$month",
        Billable:
          "$timesheets.customfields.96149",
      },
      total_duration: {
        $sum: "$timesheets.duration",
      },
    },
  },
  {
    $match: {
      "_id.Billable": {
        $ne: "",
      },
    },
  },
  {
    $addFields: {
      Month: "$_id.month",
      Billable: "$_id.Billable",
      Duration: "$total_duration",
    },
  },
  {
    $project:
      /**
       * specifications: The fields to
       *   include or exclude.
       */
      {
        _id: 0,
        Month: 1,
        Billable: 1,
        Duration: 1,
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: {
          month: "$Month",
          jobcode_id: "$Billable",
        },
        total_duration: {
          $sum: "$Duration",
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
        _id: "$_id.month",
        Category: {
          $push: {
            jobcode_id: "$_id.jobcode_id",
            name: "Billable",
            Hours: {
              $divide: ["$total_duration", 3600],
            },
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
        _id: 0,
        Month: "$_id",
        Category: 1,
      },
  },
  // {
  //   $out:
  //     /**
  //      * Provide the name of the output collection.
  //      */
  //     "MonthWiseBillableData",
  // }
]