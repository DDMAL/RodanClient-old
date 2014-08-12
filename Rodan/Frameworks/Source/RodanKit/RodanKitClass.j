/*
 * RodanKitClass.j
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

@import <Foundation/CPObject.j>


/*!
    This class is defined to make it easier to find the bundle,
    for example to get an image from the framework like this:

    @code
    var path = [[CPBundle bundleForClass:MyFramework] pathForResource:@"email-action.png"];
    @endcode

    You can also use [MyFramework version] to get the current version.
*/
@implementation RodanKit : CPObject
/*+ (void)initialize
{
    [RodanKit _registerValueTransformers];
}*/

+ (int)version
{
    var bundle = [CPBundle bundleForClass:[self class]];

    return [bundle objectForInfoDictionaryKey:@"CPBundleVersion"];
}
/*
+ (void)_registerValueTransformers
{
    arrayCountTransformer = [[ArrayCountTransformer alloc] init];
    [ArrayCountTransformer setValueTransformer:arrayCountTransformer forName:@"ArrayCountTransformer"];

    dateFormatTransformer = [[DateFormatTransformer alloc] init];
    [DateFormatTransformer setValueTransformer:dateFormatTransformer forName:@"DateFormatTransformer"];

    runJobStatusTransformer = [[RunJobStatusTransformer alloc] init];
    [RunJobStatusTransformer setValueTransformer:runJobStatusTransformer forName:@"RunJobStatusTransformer"];
}*/
@end
