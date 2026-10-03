import { getServerSession } from "next-auth/next";
import { cache } from "react";

import { authConfig } from "./config";

const auth = cache(() => getServerSession(authConfig));

export { auth };
