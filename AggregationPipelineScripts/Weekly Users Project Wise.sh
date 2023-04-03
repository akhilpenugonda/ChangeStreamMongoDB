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
    $group: {
      _id: {
        week: {
          $week: {
            $toDate: "$timesheets.date",
          },
        },
        jobcode_id: "$timesheets.jobcode_id",
        user_id: "$timesheets.user_id",
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
    $unwind: {
      path: "$job",
    },
  },
  {
    $group: {
      _id: {
        week: "$_id.week",
        jobcode_id: "$_id.jobcode_id",
      },
      users: {
        $push: "$_id.user_id",
      },
      job_name: {
        $first: "$job.name",
      },
    },
  },
  {
    $lookup: {
      from: "users",
      localField: "users",
      foreignField: "_id",
      as: "users",
    },
  },
  {
    $project: {
      _id: 0,
      Week: {
        $concat: [
          "Week-",
          {
            $toString: "$_id.week",
          },
        ],
      },
      Jobcode: "$job_name",
      users: {
        $map: {
          input: "$users",
          as: "user",
          in: {
            UserName: {
              $concat: [
                "$$user.first_name",
                " ",
                "$$user.last_name",
              ],
            },
          },
        },
      },
    },
  },
  {
    $sort: {
      Week: 1,
    },
  },
  {
    $group: {
      _id: "$Week",
      users_data: {
        $push: {
          Project: "$Jobcode",
          Users: "$users",
        },
      },
    },
  },
  {
    $out: "weekly_users_per_jobcode",
  },
]