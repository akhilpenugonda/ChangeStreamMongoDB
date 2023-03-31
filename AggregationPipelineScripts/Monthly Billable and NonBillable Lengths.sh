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
          jobcode_id: "$timesheets.jobcode_id",
          billability:
            "$timesheets.customfields.96149",
        },
        total_duration: {
          $sum: "$timesheets.duration",
        },
      },
    },
    {
      $lookup: {
        from: "JobCodes",
        localField: "_id.jobcode_id",
        foreignField: "_id",
        as: "job",
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
            month: "$_id.month",
            jobcode_id: "$_id.jobcode_id",
            billability: "$_id.billability",
          },
          total_duration: {
            $sum: "$total_duration",
          },
          name: {
            $first: "$job.name",
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
          _id: {
            month: "$_id.month",
            billability: "$_id.billability",
          },
          Category: {
            $push: {
              jobcode_id: "$_id.jobcode_id",
              name: {
                $arrayElemAt: ["$name", 0],
              },
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
          Month: "$_id.month",
          Category: 1,
          Billable: "$_id.billability",
        },
    },
    {
      $out:
        /**
         * Provide the name of the output collection.
         */
        "MonthWiseBillBasedDurations",
    },
  ]