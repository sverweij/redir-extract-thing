import httpdParser from "./httpd-parser.cjs";
import getStream from "get-stream";

function denormalizeRedirects(pVHost) {
  return pVHost.redirects.map((pRedirect) => ({
    serverName: pVHost.serverName,
    serverAliases: pVHost.serverAliases || "none",
    condition: "none",
    ...pRedirect,
  }));
}

function extractRedirects(pConfAsJSON) {
  return pConfAsJSON
    .filter((pVHost) => pVHost.redirects)
    .reduce((pAll, pVHost) => {
      return pAll.concat(denormalizeRedirects(pVHost));
    }, []);
}

function denormalizeConditionalRedirects(pVHost, pConditional) {
  return pConditional.redirects.map((pRedirect) => ({
    serverName: pVHost.serverName,
    serverAliases: pVHost.serverAliases || "none",
    condition: pConditional.condition || "none",
    ...pRedirect,
  }));
}

function extractConditionalRedirects(pConfAsJSON) {
  return pConfAsJSON
    .filter((pVHost) => pVHost.conditionals)
    .reduce((pAll, pVHost) => {
      return pAll.concat(
        pVHost.conditionals.map((pConditional) =>
          denormalizeConditionalRedirects(pVHost, pConditional)
        )
      );
    }, [])
    .flat();
}

getStream(process.stdin)
  .then((pConfig) => {
    const lConfAsJSON = httpdParser.parse(pConfig);
    console.log(`"serverName","serverAliases","condition","from","to"`);
    console.log(
      extractRedirects(lConfAsJSON)
        .concat(extractConditionalRedirects(lConfAsJSON))
        .reduce((pAll, pRedirect) => {
          return (
            pAll +
            `"${pRedirect.serverName}","${pRedirect.serverAliases}","${pRedirect.condition}","${pRedirect.from}","${pRedirect.to}"\n`
          );
        }, "")
    );
  })
  .catch((pError) => {
    console.error(pError);
  });
