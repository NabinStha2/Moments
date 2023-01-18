const Activity = require("../models/activityModel");

const getActivity = async (req, res, next) => {
  try {
    const act = await Activity.findOne({ activityUserId: req.params.id })
      .populate("postId userId activityUserId")
      .lean();
    // console.log(act);
    res.status(200).json({ message: "Success", data: act });
  } catch (err) {
    console.log(err);
    res.status(400).json({ errMessage: err.message });
  }
};

module.exports = {
  getActivity,
};
