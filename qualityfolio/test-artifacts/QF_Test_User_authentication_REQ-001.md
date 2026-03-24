---
doc-classify:
  - select: heading[depth="1"]
    role: project
  - select: heading[depth="2"]
    role: plan
  - select: heading[depth="3"]
    role: suite
  - select: heading[depth="4"]
    role: case
  - select: heading[depth="5"]
    role: evidence
---

# QF_Test_User_authentication

@id qf_test_user_authentication-project

The QF_Test_User_authentication project aims to validate the login workflow of an enterprise application, ensuring secure and user-friendly access for authorized users.

**Objectives**

- Validate login workflow
- Ensure security and compliance

**Risks**

- Security breaches
- Non-compliance with regulatory requirements

---

## Login Plan

@id PLAN-001

```yaml HFM
  plan-name: Login Plan
  plan-date: 2026-03-23
  created-by: Rahul Raj
```

**Objectives**

- Execute login test cases

**Risks**

- Test environment issues

**Cycle Goals**

- Complete testing within the given timeframe

---

## Signup Plan

@id PLAN-002

```yaml HFM
  plan-name: Signup Plan
  plan-date: 2026-03-23
  created-by: Arun
```

**Objectives**

- Complete signup plan testing

**Risks**

- Insufficient test coverage

**Cycle Goals**

- Achieve 90% test automation

---

## User Verification

@id PLAN-003

```yaml HFM
  plan-name: User Verification
  plan-date: 2026-03-23
  created-by: Arun
```

**Objectives**

- Verify email verification workflow

**Risks**

- Verification link expiration issues

**Cycle Goals**

- Achieve 100% email verification coverage

---

### Login Suite

@id SUITE-001

```yaml HFM
  suite-name: Login Suite
  suite-date: 2026-03-23
  created-by: Arun
```

**Scope**

- Login functionality

**Test Cases**

- **TC-0001** – Verify that a user can login using a valid email address and password
- **TC-0002** – Ensure login fails when an invalid password is entered with a valid email
- **TC-0003** – Validate that the password field masks input and shows a visibility toggle
- **TC-0004** – Check that the system limits the number of incorrect login attempts
- **TC-0005** – Confirm that the system provides a self-service password recovery process

#### Verify that a user can login using a valid email address and password

@id TC-0001

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the happy path login scenario with valid credentials

**Preconditions**

- [x] User has a valid email address and password
- [x] User is registered in the system

**Steps**

- [x] 1. Enter a valid email address
- [x] 2. Enter a valid password
- [x] 3. Click the login button

**Expected Results**

- [x] The user is logged in successfully and redirected to the dashboard

##### Evidence

@id TC-0001

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0001/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0001/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0001/1.0/run.auto.md)

---

#### Ensure login fails when an invalid password is entered with a valid email

@id TC-0002

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","UI"]
  Scenario Type: Negative
  Execution Type: Manual
```

**Description**

Test the login failure scenario with an invalid password

**Preconditions**

- [x] User has a valid email address
- [x] User has an invalid password

**Steps**

- [x] 1. Enter a valid email address
- [x] 2. Enter an invalid password
- [x] 3. Click the login button

**Expected Results**

- [x] The login fails and an error message is displayed

##### Evidence

@id TC-0002

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0002/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0002/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0002/1.0/run.auto.md)

---

#### Validate that the password field masks input and shows a visibility toggle

@id TC-0003

```yaml HFM
  requirementID: REQ-001
  Priority: Low
  Tags: ["UI","Functional"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the password field functionality

**Preconditions**

- [x] User is on the login page

**Steps**

- [x] 1. Click on the password field
- [x] 2. Enter a password
- [x] 3. Check if the input is masked
- [x] 4. Click on the visibility toggle

**Expected Results**

- [x] The password input is masked and the visibility toggle works as expected

##### Evidence

@id TC-0003

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Low
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0003/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0003/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0003/1.0/run.auto.md)

---

#### Check that the system limits the number of incorrect login attempts

@id TC-0004

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Security","Functional"]
  Scenario Type: Boundarys
  Execution Type: Automated
```

**Description**

Test the login attempt limit scenario

**Preconditions**

- [x] User has a valid email address
- [x] User has an invalid password

**Steps**

- [x] 1. Enter a valid email address
- [x] 2. Enter an invalid password
- [x] 3. Repeat steps 1-2 until the limit is reached

**Expected Results**

- [x] The system locks out the user after the specified number of attempts

##### Evidence

@id TC-0004

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0004/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0004/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0004/1.0/run.auto.md)

---

#### Confirm that the system provides a self-service password recovery process

@id TC-0005

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","UI"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the password recovery scenario

**Preconditions**

- [x] User has a valid email address
- [x] User has forgotten their password

**Steps**

- [x] 1. Click on the forgot password link
- [x] 2. Enter the valid email address
- [x] 3. Follow the password recovery process

**Expected Results**

- [x] The user is able to recover their password successfully

##### Evidence

@id TC-0005

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0005/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0005/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0005/1.0/run.auto.md)

---

### Logout Suite

@id SUITE-002

```yaml HFM
  suite-name: Logout Suite
  suite-date: 2026-03-23
  created-by: Rahul Raj
```

**Scope**

- Validate logout functionality

**Test Cases**

- **TC-0001** – Verify that a user can logout successfully using the logout option
- **TC-0002** – Ensure that the system initiates a logout workflow when a session timeout occurs due to inactivity
- **TC-0003** – Validate that the system handles logout requests from multiple devices or sessions simultaneously
- **TC-0004** – Check that the system displays a logout confirmation message to the user after a successful logout
- **TC-0005** – Confirm that the system handles exceptions and errors during the logout process and provides a meaningful error message

#### Verify that a user can logout successfully using the logout option

@id TC-0001

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the logout workflow when a user intentionally selects the logout option

**Preconditions**

- [x] User is logged in

**Steps**

- [x] 1. Login to the system
- [x] 2. Click the logout option

**Expected Results**

- [x] The user is redirected to the login page and the session is terminated

##### Evidence

@id TC-0001

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0001/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0001/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0001/1.0/run.auto.md)

---

#### Ensure that the system initiates a logout workflow when a session timeout occurs due to inactivity

@id TC-0002

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the logout workflow when a session timeout occurs due to inactivity

**Preconditions**

- [x] User is logged in
- [x] Inactivity timeout is set

**Steps**

- [x] 1. Login to the system
- [x] 2. Wait for the inactivity timeout

**Expected Results**

- [x] The user is redirected to the login page and the session is terminated

##### Evidence

@id TC-0002

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0002/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0002/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0002/1.0/run.auto.md)

---

#### Validate that the system handles logout requests from multiple devices or sessions simultaneously

@id TC-0003

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the logout workflow when a user is logged in from multiple locations

**Preconditions**

- [x] User is logged in from multiple devices

**Steps**

- [x] 1. Login to the system from multiple devices
- [x] 2. Logout from one device

**Expected Results**

- [x] The user is logged out from all devices and the session is terminated

##### Evidence

@id TC-0003

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0003/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0003/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0003/1.0/run.auto.md)

---

#### Check that the system displays a logout confirmation message to the user after a successful logout

@id TC-0004

```yaml HFM
  requirementID: REQ-001
  Priority: Low
  Tags: ["UI","Smoke"]
  Scenario Type: UI
  Execution Type: Manual
```

**Description**

Test the logout confirmation message

**Preconditions**

- [x] User is logged in

**Steps**

- [x] 1. Login to the system
- [x] 2. Click the logout option

**Expected Results**

- [x] A logout confirmation message is displayed to the user

##### Evidence

@id TC-0004

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Low
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0004/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0004/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0004/1.0/run.auto.md)

---

#### Confirm that the system handles exceptions and errors during the logout process and provides a meaningful error message

@id TC-0005

```yaml HFM
  requirementID: REQ-001
  Priority: Critical
  Tags: ["Functional","Regression"]
  Scenario Type: Negative
  Execution Type: Automated
```

**Description**

Test the logout workflow with exceptions and errors

**Preconditions**

- [x] User is logged in

**Steps**

- [x] 1. Login to the system
- [x] 2. Simulate an error during logout

**Expected Results**

- [x] A meaningful error message is displayed to the user and the system handles the exception

##### Evidence

@id TC-0005

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Critical
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0005/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0005/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0005/1.0/run.auto.md)

---

### Signup Suite

@id SUITE-001

```yaml HFM
  suite-name: Signup Suite
  suite-date: 2026-03-23
  created-by: Arun
```

**Scope**

- Signup suite testing

**Test Cases**

- **TC-0001** – Verify that a user can successfully signup using valid registration information
- **TC-0002** – Ensure that the system validates user input data and displays error messages for invalid formats
- **TC-0003** – Validate that the system sends a verification email to the user's registered email address upon successful signup
- **TC-0004** – Check that the system requires users to verify their email address before granting full access
- **TC-0005** – Confirm that the system handles errors and exceptions during the signup process and provides clear error messages

#### Verify that a user can successfully signup using valid registration information

@id TC-0001

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the happy path scenario for user signup

**Preconditions**

- [x] User does not have an existing account

**Steps**

- [x] 1. Launch the signup page
- [x] 2. Enter valid registration information
- [x] 3. Submit the signup form

**Expected Results**

- [x] User is successfully signed up and receives a verification email

##### Evidence

@id TC-0001

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0001/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0001/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0001/1.0/run.auto.md)

---

#### Ensure that the system validates user input data and displays error messages for invalid formats

@id TC-0002

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","UI"]
  Scenario Type: Negative
  Execution Type: Manual
```

**Description**

Test the system's input validation and error handling

**Preconditions**

- [x] User is on the signup page

**Steps**

- [x] 1. Enter invalid email address format
- [x] 2. Enter weak password
- [x] 3. Submit the signup form

**Expected Results**

- [x] System displays error messages for invalid input formats

##### Evidence

@id TC-0002

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0002/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0002/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0002/1.0/run.auto.md)

---

#### Validate that the system sends a verification email to the user's registered email address upon successful signup

@id TC-0003

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the verification email sending functionality

**Preconditions**

- [x] User has successfully signed up

**Steps**

- [x] 1. Verify that the user receives a verification email
- [x] 2. Check the email content for correctness

**Expected Results**

- [x] User receives a verification email with correct content

##### Evidence

@id TC-0003

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0003/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0003/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0003/1.0/run.auto.md)

---

#### Check that the system requires users to verify their email address before granting full access

@id TC-0004

```yaml HFM
  requirementID: REQ-001
  Priority: Critical
  Tags: ["Security","Functional"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the email verification requirement

**Preconditions**

- [x] User has received the verification email

**Steps**

- [x] 1. Do not verify the email address
- [x] 2. Attempt to access the system's features

**Expected Results**

- [x] System does not grant full access until email address is verified

##### Evidence

@id TC-0004

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Critical
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0004/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0004/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0004/1.0/run.auto.md)

---

#### Confirm that the system handles errors and exceptions during the signup process and provides clear error messages

@id TC-0005

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","UI"]
  Scenario Type: Boundarys
  Execution Type: Manual
```

**Description**

Test the system's error handling and error messaging

**Preconditions**

- [x] User is on the signup page

**Steps**

- [x] 1. Simulate a network error during signup
- [x] 2. Check the error message displayed

**Expected Results**

- [x] System displays a clear and concise error message

##### Evidence

@id TC-0005

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0005/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0005/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0005/1.0/run.auto.md)

---

### Forgot Password Suite

@id SUITE-002

```yaml HFM
  suite-name: Forgot Password Suite
  suite-date: 2026-03-23
  created-by: Arun
```

**Scope**

- Forgot Password Suite

**Test Cases**

- **TC-0001** – Verify that a user can initiate the password recovery process using a valid email address
- **TC-0002** – Ensure that the system validates the user's identity through a validation process before sending a password recovery email
- **TC-0003** – Validate that the password reset page requires the user to enter a new password and confirm the new password with password complexity rules
- **TC-0004** – Check that the system implements rate limiting on password reset attempts to prevent brute-force attacks
- **TC-0005** – Confirm that the system provides clear instructions and feedback to the user throughout the password recovery process

#### Verify that a user can initiate the password recovery process using a valid email address

@id TC-0001

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the forgot password feature with a valid email address

**Preconditions**

- [x] User has a valid email address
- [x] User has forgotten their password

**Steps**

- [x] 1. Click on the forgot password link
- [x] 2. Enter a valid email address
- [x] 3. Click on the submit button

**Expected Results**

- [x] A password recovery email is sent to the user's email address

##### Evidence

@id TC-0001

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0001/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0001/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0001/1.0/run.auto.md)

---

#### Ensure that the system validates the user's identity through a validation process before sending a password recovery email

@id TC-0002

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","API"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the validation process for password recovery

**Preconditions**

- [x] User has a valid email address
- [x] User has forgotten their password

**Steps**

- [x] 1. Enter an invalid email address
- [x] 2. Click on the submit button
- [x] 3. Verify the error message

**Expected Results**

- [x] An error message is displayed indicating that the email address is invalid

##### Evidence

@id TC-0002

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0002/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0002/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0002/1.0/run.auto.md)

---

#### Validate that the password reset page requires the user to enter a new password and confirm the new password with password complexity rules

@id TC-0003

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the password reset page with password complexity rules

**Preconditions**

- [x] User has received a password recovery email
- [x] User has clicked on the password reset link

**Steps**

- [x] 1. Enter a new password
- [x] 2. Confirm the new password
- [x] 3. Click on the submit button

**Expected Results**

- [x] The password is updated successfully and a confirmation email is sent to the user

##### Evidence

@id TC-0003

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0003/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0003/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0003/1.0/run.auto.md)

---

#### Check that the system implements rate limiting on password reset attempts to prevent brute-force attacks

@id TC-0004

```yaml HFM
  requirementID: REQ-001
  Priority: Critical
  Tags: ["Security","API"]
  Scenario Type: Security
  Execution Type: Automated
```

**Description**

Test the rate limiting feature for password reset attempts

**Preconditions**

- [x] User has a valid email address
- [x] User has forgotten their password

**Steps**

- [x] 1. Attempt to reset the password multiple times with incorrect credentials
- [x] 2. Verify the error message

**Expected Results**

- [x] An error message is displayed indicating that the account is temporarily locked due to excessive attempts

##### Evidence

@id TC-0004

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Critical
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0004/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0004/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0004/1.0/run.auto.md)

---

#### Confirm that the system provides clear instructions and feedback to the user throughout the password recovery process

@id TC-0005

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["UI","Regression"]
  Scenario Type: UI
  Execution Type: Manual
```

**Description**

Test the user interface for the password recovery process

**Preconditions**

- [x] User has a valid email address
- [x] User has forgotten their password

**Steps**

- [x] 1. Initiate the password recovery process
- [x] 2. Verify the instructions and feedback provided to the user

**Expected Results**

- [x] The user is provided with clear instructions and feedback throughout the password recovery process

##### Evidence

@id TC-0005

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0005/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0005/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0005/1.0/run.auto.md)

---

### Verification Suite

@id SUITE-001

```yaml HFM
  suite-name: Verification Suite
  suite-date: 2026-03-23
  created-by: Arun
```

**Scope**

- Email verification functionality

**Test Cases**

- **TC-0001** – Verify that a user receives a verification email upon registration with a valid email address
- **TC-0002** – Ensure that the system prevents users with unverified email addresses from accessing certain features
- **TC-0003** – Validate that the system allows users to request a new verification email if the initial email is not received
- **TC-0004** – Check that the system logs all email verification attempts, including successful and failed attempts
- **TC-0005** – Confirm that the system provides users with clear instructions and feedback throughout the email verification process

#### Verify that a user receives a verification email upon registration with a valid email address

@id TC-0001

```yaml HFM
  requirementID: REQ-001
  Priority: High
  Tags: ["Functional","Regression"]
  Scenario Type: Functional
  Execution Type: Manual
```

**Description**

Test the email verification process for a new user registration

**Preconditions**

- [x] User is not registered
- [x] Valid email address is used

**Steps**

- [x] 1. Register a new user with a valid email address
- [x] 2. Check the email inbox for the verification email

**Expected Results**

- [x] The user receives a verification email with a unique verification link

##### Evidence

@id TC-0001

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: High
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0001/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0001/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0001/1.0/run.auto.md)

---

#### Ensure that the system prevents users with unverified email addresses from accessing certain features

@id TC-0002

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","API"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the access restrictions for unverified email addresses

**Preconditions**

- [x] User is registered with an unverified email address

**Steps**

- [x] 1. Attempt to access a restricted feature
- [x] 2. Verify the access denial message

**Expected Results**

- [x] The system denies access to the feature and displays an error message

##### Evidence

@id TC-0002

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0002/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0002/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0002/1.0/run.auto.md)

---

#### Validate that the system allows users to request a new verification email if the initial email is not received

@id TC-0003

```yaml HFM
  requirementID: REQ-001
  Priority: Low
  Tags: ["Functional","UI"]
  Scenario Type: Boundarys
  Execution Type: Manual
```

**Description**

Test the re-verification email request process

**Preconditions**

- [x] User is registered with an unverified email address
- [x] Initial verification email was not received

**Steps**

- [x] 1. Request a new verification email
- [x] 2. Check the email inbox for the new verification email

**Expected Results**

- [x] The user receives a new verification email with a unique verification link

##### Evidence

@id TC-0003

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Low
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0003/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0003/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0003/1.0/run.auto.md)

---

#### Check that the system logs all email verification attempts, including successful and failed attempts

@id TC-0004

```yaml HFM
  requirementID: REQ-001
  Priority: Critical
  Tags: ["Functional","API"]
  Scenario Type: Functional
  Execution Type: Automated
```

**Description**

Test the email verification logging mechanism

**Preconditions**

- [x] User is registered with a valid email address

**Steps**

- [x] 1. Attempt to verify the email address
- [x] 2. Check the system logs for the verification attempt

**Expected Results**

- [x] The system logs the verification attempt, including the outcome

##### Evidence

@id TC-0004

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Critical
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0004/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0004/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0004/1.0/run.auto.md)

---

#### Confirm that the system provides users with clear instructions and feedback throughout the email verification process

@id TC-0005

```yaml HFM
  requirementID: REQ-001
  Priority: Medium
  Tags: ["Functional","UI"]
  Scenario Type: Negative
  Execution Type: Manual
```

**Description**

Test the user feedback and instructions during the email verification process

**Preconditions**

- [x] User is registered with an unverified email address

**Steps**

- [x] 1. Attempt to verify the email address with an invalid verification link
- [x] 2. Verify the error message and instructions

**Expected Results**

- [x] The system displays clear error messages and instructions for the user to follow

##### Evidence

@id TC-0005

```yaml META
  cycle: 1.0
  cycle-date: 03-23-2026
  severity: Medium
  assignee: Ajesh Jose
  status: To-do
```

**Attachments**

- [Result JSON](./evidence/TC-0005/1.0/result.auto.json)
- [Screenshot](./evidence/TC-0005/1.0/screenshot.auto.png)
- [Run MD](./evidence/TC-0005/1.0/run.auto.md)

---

