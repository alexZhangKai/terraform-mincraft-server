const Compute = require('@google-cloud/compute')

/**
 * Stop minecraft server.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.stopServer = async (req, res) => {
  let command = req.body.command;
  const compute = new Compute();
  switch(command){
    case "stop":
      const [stopOperation] = await compute
        .zone("australia-southeast1-b")
        .vm("tf-mc-server")
        .stop();
      await stopOperation.promise();
      res.status(200).send("server stopped");
      return;
    case "start":
      const [startOperation] = await compute
        .zone("australia-southeast1-b")
        .vm("tf-mc-server")
        .start();
      await startOperation.promise();
      res.status(200).send("server started");
      return;
    default:
      console.error("invalid command")
  }
  res.status(400).send("invalid command");
  return;
};