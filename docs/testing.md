# Testing

Lakeshore employs the Amen testing framework to ensure correct behavior and adherence to the Belmont provider specifications.

## Approach

The test suite validates Lakeshore's functionality against the standard Belmont conformance tests. The suite defines a custom factory that sets up various mock scenarios—including existing, missing, creatable, and unsupported resources. These scenarios utilize `Lakeshore.register` and `@dashkite/storage` to simulate the required environments for the conformance assertions.

## Running the Tests

To execute the test suite, run the following command in your terminal:

```bash
npx genie test
```
