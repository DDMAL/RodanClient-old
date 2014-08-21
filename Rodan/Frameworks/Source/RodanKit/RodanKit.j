/*
 * RodanKit.j
 * RodanKit
 *
 * Created by You on August 11, 2014.
 *
 * Copyright 2014, Your Company. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
    USAGE

    Put an @import of every source file in your framework here. Users of the framework
    can then simply import this file instead of having to know what the individual
    source filenames are.
*/

// Timer events.
RodanWorkflowResultsTimerNotification = @"RodanWorkflowResultsTimerNotification";

// Model messages (via WLRemoteObject delegate).
RodanModelCreatedNotification = @"RodanModelCreatedNotification";
RodanModelDeletedNotification = @"RodanModelDeletedNotification";
RodanModelLoadedNotification = @"RodanModelLoadedNotification";

// Load success events.
RodanDidLoadJobsNotification = @"RodanDidLoadJobsNotification";
RodanDidLoadWorkflowNotification = @"RodanDidLoadWorkflowNotification";
RodanDidLoadWorkflowsNotification = @"RodanDidLoadWorkflowsNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanDidLogOutNotification = @"RodanDidLogOutNotification";

// Request events.
RodanRequestWorkflowsNotification = @"RodanRequestWorkflowsNotification";
RodanRequestInteractiveJobsNotification = @"RodanRequestInteractiveJobsNotification";
RodanRequestWorkflowRunsNotification = @"RodanRequestWorkflowRunsNotification";
RodanRequestWorkflowPagesNotification = @"RodanRequestWorkflowPagesNotification";
RodanRequestWorkflowRunsJobsNotification = @"RodanRequestWorkflowRunsJobsNotification";
RodanRequestResourcesNotification = @"RodanRequestResourcesNotification";
RodanRequestWorkflowPageResultsNotification = @"RodanRequestWorkflowPageResultsNotification";
RodanRequestRunJobsNotification = @"RodanRequestRunJobsNotification";
RodanRequestWorkflowResultsPackagesNotification = @"RodanRequestWorkflowResultsPackagesNotification";

// Focus events.
RodanHasFocusInteractiveJobsViewNotification = @"RodanHasFocusInteractiveJobsViewNotification";
RodanHasFocusWorkflowResultsViewNotification = @"RodanHasFocusWorkflowResultsViewNotification";
RodanHasFocusResourcesViewNotification = @"RodanHasFocusResourcesViewNotification";
RodanHasFocusProjectListViewNotification = @"RodanHasFocusProjectListViewNotification";

@import "RodanKitClass.j"

// Controllers
@import "AuthenticationController.j"
@import "JobController.j"
@import "ResourceController.j"
@import "RKController.j"
@import "WorkflowController.j"

// Models
@import "Connection.j"
@import "Input.j"
@import "InputPort.j"
@import "InputPortType.j"
@import "Job.j"
@import "Output.j"
@import "OutputPort.j"
@import "OutputPortType.j"
@import "Project.j"
@import "Resource.j"
@import "ResourceAssignment.j"
@import "Result.j"
@import "ResultsPackage.j"
@import "RKModel.j"
@import "RunJob.j"
@import "User.j"
@import "Workflow.j"
@import "WorkflowJob.j"
@import "WorkflowJobSetting.j"
@import "WorkflowRun.j"

// Transformers
@import "ArrayCountTransformer.j"
@import "ByteCountTransformer.j"
@import "CheckBoxTransformer.j"
@import "JobTypeTransformer.j"
@import "JobArgumentsTransformer.j"
@import "PngTransformer.j"
@import "RunJobSettingsTransformer.j"
@import "RunJobStatusTransformer.j"
@import "UsernameTransformer.j"