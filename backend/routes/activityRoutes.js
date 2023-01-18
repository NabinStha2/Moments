const { getActivity } = require("../controllers/activityController");

const router = require("express").Router();

router.get("/:id", getActivity);

module.exports = router;
