[
  {
    $project: {
      jobcode: {
        $map: {
          input: {
            $objectToArray:
              "$supplemental_data.jobcodes",
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
        jobcode: 1,
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
        path: "$jobcode",
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$jobcode.id",
        billable: {
          $first: "$jobcode.billable",
        },
        name: {
          $first: "$jobcode.name",
        },
        type: {
          $first: "$jobcode.type",
        },
      },
  },
  {
    $sort:
      /**
       * Provide any number of field/order pairs.
       */
      {
        type: 1,
      },
  },
  // {
  //   $group:
  //     /**
  //      * _id: The id of the group.
  //      * fieldN: The first field name.
  //      */
  //     {
  //       _id: null,
  //       data: {
  //         $addToSet: "$jobcodes",
  //       },
  //     },
  // },
  {
    $out:
      /**
       * Provide the name of the output collection.
       */
      "JobCodes",
  },
]