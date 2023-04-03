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
      week: {
        $concat: [
          "Week-",
          {
            $toString: "$_id.week",
          },
        ],
      },
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
      _id: "$week",
      users_data: {
        $push: {
          user: "$user",
          notes: "$notes",
        },
      },
    },
  },
  {
    $out: "weekly_nonbillable_users_notes",
  },
]