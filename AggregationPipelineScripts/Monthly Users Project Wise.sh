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
    $group: {
      _id: {
        month: "$month",
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
        month: "$_id.month",
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
      Month: "$_id.month",
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
      Month: 1,
    },
  },
  {
    $group: {
      _id: "$Month",
      users_data: {
        $push: {
          Project: "$Jobcode",
          Users: "$users",
        },
      },
    },
  },
  {
    $out: "monthly_users_per_jobcode",
  },
]