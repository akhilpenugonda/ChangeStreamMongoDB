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
    $match: {
      "timesheets.customfields.96149": "No",
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
    $unwind: {
      path: "$timesheets",
    },
  },
  {
    $group: {
      _id: {
        month: "$month",
        user_id: "$timesheets.user_id",
      },
      notes: {
        $push: "$timesheets.notes",
      },
    },
  },
  {
    $lookup: {
      from: "users",
      localField: "_id.user_id",
      foreignField: "_id",
      as: "user",
    },
  },
  {
    $project: {
      _id: 0,
      month: "$_id.month",
      notes: 1,
      user: {
        $concat: [
          {
            $arrayElemAt: ["$user.first_name", 0],
          },
          " ",
          {
            $arrayElemAt: ["$user.last_name", 0],
          },
        ],
      },
    },
  },
  {
    $group: {
      _id: "$month",
      users_data: {
        $push: {
          user: "$user",
          notes: "$notes",
        },
      },
    },
  },
  {
    $out: "monthly_nonbillable_users_notes",
  },
]