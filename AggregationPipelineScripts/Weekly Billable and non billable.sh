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
    $unwind: {
      path: "$timesheets",
    },
  },
  {
    $addFields: {
      week: {
        $week: {
          $toDate: "$timesheets.date",
        },
      },
    },
  },
  {
    $group: {
      _id: "$week",
      timesheets: {
        $push: "$timesheets",
      },
    },
  },
  {
    $project: {
      _id: 0,
      week: "$_id",
      timesheets: 1,
    },
  },
  {
    $unwind: {
      path: "$timesheets",
    },
  },
  {
    $group: {
      _id: {
        week: "$week",
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
      from: "job_codes",
      localField: "_id.jobcode_id",
      foreignField: "_id",
      as: "job",
    },
  },
  {
    $group: {
      _id: {
        week: "$_id.week",
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
    $group: {
      _id: {
        week: "$_id.week",
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
    $project: {
      _id: 0,
      Week: {
        $concat: [
          "Week ",
          {
            $toString: "$_id.week",
          },
        ],
      },
      Category: 1,
      Billable: "$_id.billability",
    },
  },
  {
    $sort: {
      Week: 1,
    },
  },
  {
    $out: "weekly_billable_project",
  },
]